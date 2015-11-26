using System.Collections.Generic;
using System.Globalization;
using System.Net.Mail;
using UCommerce.EntitiesV2;
using UCommerce.Infrastructure.Configuration;
using UCommerce.Infrastructure.Globalization;
using UCommerce.Pipelines;
using UCommerce.Runtime;
using UCommerce.Transactions;

namespace MyUCommerceApp.BusinessLogic.Pipelines
{
    public class NotifyOnVipBasketTask : IPipelineTask<PurchaseOrder>
    {
        private readonly IEmailService _emailService;
       
        private readonly ICatalogContext _catalogContext;
        private readonly CommerceConfigurationProvider _commerceConfigurationProvider;
        private readonly int _threshold;

        public NotifyOnVipBasketTask(IEmailService emailService, ICatalogContext catalogContext, CommerceConfigurationProvider commerceConfigurationProvider, int threshold)
        {
            _emailService = emailService;
            _catalogContext = catalogContext;
            _commerceConfigurationProvider = commerceConfigurationProvider;
            _threshold = threshold;
        }

        public PipelineExecutionResult Execute(PurchaseOrder subject)
        {
            if (subject.OrderTotal.HasValue && subject.OrderTotal.Value > _threshold)
            {
                var localizationContext = new CustomGlobalization(_commerceConfigurationProvider);
                localizationContext.SetCulture(new CultureInfo(subject.CultureCode));

                _emailService.Send(localizationContext, _catalogContext.CurrentCatalogGroup.EmailProfile,
                    "VIP notification", new MailAddress("lasse.eskildsen@ucommerce.net"),
                    new Dictionary<string, string>
                    {
                        {"orderGuid", subject.OrderGuid.ToString()},
                        {"orderValue", subject.OrderTotal.Value.ToString()}
                    });
            }

            return PipelineExecutionResult.Success;
        }

    }
}