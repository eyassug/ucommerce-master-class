using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Net.Mail;
using System.Text;
using UCommerce.EntitiesV2;
using UCommerce.Infrastructure.Configuration;
using UCommerce.Infrastructure.Globalization;
using UCommerce.Pipelines;
using UCommerce.Runtime;
using UCommerce.Transactions;

namespace MyUCommerceApp.Pipelines
{
	public class NotifyOnVipOrder : IPipelineTask<PurchaseOrder>
	{
		private readonly CommerceConfigurationProvider _configProvider;
		private readonly ICatalogContext _catalogContext;
		private readonly IEmailService _emailService;
		private readonly int _vipAmountThresHold;

		public NotifyOnVipOrder(
			CommerceConfigurationProvider configProvider, 
			ICatalogContext catalogContext, 
			IEmailService emailService, 
			int vipAmountThresHold)
		{
			_configProvider = configProvider;
			_catalogContext = catalogContext;
			_emailService = emailService;
			_vipAmountThresHold = vipAmountThresHold;
		}

		public PipelineExecutionResult Execute(PurchaseOrder subject)
		{
			if (subject.OrderTotal.Value > _vipAmountThresHold)
			{
				var localizationContext = new CustomGlobalization(_configProvider);
				localizationContext.SetCulture(new CultureInfo(subject.CultureCode));

				var emailParams = new Dictionary<string, string>();
				emailParams.Add("orderGuid",subject.OrderGuid.ToString());
				emailParams.Add("orderValue", subject.OrderTotal.Value.ToString());

				_emailService.Send(
					localizationContext,
					_catalogContext.CurrentCatalogGroup.EmailProfile,
					"VipNotification",
					new MailAddress("msk@ucommerce.net"),
					emailParams
				);

			}

			return PipelineExecutionResult.Success;
		}
	}
}
