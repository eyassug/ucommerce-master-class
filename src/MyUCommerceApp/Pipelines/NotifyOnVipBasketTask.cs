using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Mail;
using System.Text;
using UCommerce.EntitiesV2;
using UCommerce.Infrastructure.Globalization;
using UCommerce.Pipelines;
using UCommerce.Runtime;
using UCommerce.Transactions;

namespace MyUCommerceApp.BusinessLogic.Pipelines
{
    /// <summary>
    /// Notify store manager via email when basket reaches a configured threshold.
    /// </summary>
    public class NotifyOnVipBasketTask : IPipelineTask<PurchaseOrder>
    {
        private readonly IEmailService _emailService;
        private readonly ILocalizationContext _localizationContext;
        private readonly ICatalogContext _catalogContext;

        public NotifyOnVipBasketTask(IEmailService emailService,
            ILocalizationContext localizationContext,
            ICatalogContext catalogContext)
        {
            _emailService = emailService;
            _localizationContext = localizationContext;
            _catalogContext = catalogContext;
        }

        public PipelineExecutionResult Execute(PurchaseOrder subject)
        {
            if (subject.OrderTotal < VipThreshold) return PipelineExecutionResult.Success;

            var emailProfile = _catalogContext.CurrentCatalogGroup.EmailProfile;

            var paramss = new Dictionary<string, string>();
            paramss.Add("orderGuid", subject.OrderGuid.ToString());

            _emailService.Send(_localizationContext, emailProfile, "OrderConfirmation",
                new MailAddress("paul@arlanet.com"), paramss);

            return PipelineExecutionResult.Success;
        }

        public decimal VipThreshold { get; set; }
    }
}
