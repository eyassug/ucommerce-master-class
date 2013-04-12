using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Net.Mail;
using System.Text;
using System.Threading.Tasks;
using UCommerce.EntitiesV2;
using UCommerce.Infrastructure.Configuration;
using UCommerce.Infrastructure.Globalization;
using UCommerce.Pipelines;
using UCommerce.Transactions;

namespace MyUCommerceApp.Library.Pipelines
{
	public class NotifyOnVipBasket : IPipelineTask<PurchaseOrder>
	{
		private readonly IEmailService _emailService;
		private readonly CommerceConfigurationProvider _configProvider;
		private readonly int _vipBasketThreshold;

		public NotifyOnVipBasket(IEmailService emailService, 
			CommerceConfigurationProvider configProvider, 
			int vipBasketThreshold)
		{
			_emailService = emailService;
			_configProvider = configProvider;
			_vipBasketThreshold = vipBasketThreshold;
		}

		public PipelineExecutionResult Execute(PurchaseOrder order)
		{
			if (order.OrderTotal > _vipBasketThreshold)
			{
				CustomGlobalization customLocale 
					= new CustomGlobalization(_configProvider);
				customLocale.SetCulture(new CultureInfo(order.CultureCode));

				var emailParams = new Dictionary<string, string>();
				emailParams.Add("orderGuid", order.OrderGuid.ToString());
				emailParams.Add("orderTotal", order.OrderTotal.Value.ToString());
				_emailService.Send(customLocale,
				                   order.ProductCatalogGroup.EmailProfile,
				                   "VIP basket notification",
				                   new MailAddress("ssl@ucommerce.dk"),
								   emailParams);
			}

			return PipelineExecutionResult.Success;
		}
	}
}
