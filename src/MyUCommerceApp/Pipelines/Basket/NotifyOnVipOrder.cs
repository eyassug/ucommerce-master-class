using System.Collections.Generic;
using System.Globalization;
using System.Net.Mail;
using UCommerce.EntitiesV2;
using UCommerce.Infrastructure.Configuration;
using UCommerce.Infrastructure.Globalization;
using UCommerce.Pipelines;
using UCommerce.Runtime;
using UCommerce.Transactions;

namespace MyUCommerceApp.Pipelines.Basket
{
	public class NotifyOnVipOrder : IPipelineTask<PurchaseOrder>
	{
		private readonly CommerceConfigurationProvider _provider;
		private readonly IEmailService _service;
		private readonly ICatalogContext _catalogContext;

		public NotifyOnVipOrder(CommerceConfigurationProvider provider,
								IEmailService service,
								ICatalogContext catalogContext)
		{
			_provider = provider;
			_service = service;
			_catalogContext = catalogContext;
		}

		public PipelineExecutionResult Execute(PurchaseOrder basket)
		{
			if (basket.OrderTotal > 500)
			{
				var localization = new CustomGlobalization(_provider);
				localization.SetCulture(new CultureInfo(basket.CultureCode));

				var queryStringParams = new Dictionary<string, string>();
				queryStringParams.Add("orderguid", basket.OrderGuid.ToString());
				queryStringParams.Add("orderid", basket.OrderId.ToString(CultureInfo.InvariantCulture));
				var emailProfile = _catalogContext.CurrentCatalogGroup.EmailProfile;

				_service.Send(localization, emailProfile, "VIP Orders", new MailAddress("mak@vertica.dk"), queryStringParams);
			}
			return PipelineExecutionResult.Success;
		}
	}
}