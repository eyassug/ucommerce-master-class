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

namespace MyUCommerceApp.BusinessLogic.Pipelines
{
	public class SendVipEmailTask : IPipelineTask<UCommerce.EntitiesV2.PurchaseOrder>
	{
		private readonly int _vipThreshold;
		private readonly IEmailService _emailService;
		private readonly ICatalogContext _catalogContext;
		private readonly CommerceConfigurationProvider _configurationProvider;

		public SendVipEmailTask(
			int vipThreshold, 
			IEmailService emailService,
			ICatalogContext catalogContext, 
			CommerceConfigurationProvider configurationProvider)
		{
			_vipThreshold = vipThreshold;
			_emailService = emailService;
			_catalogContext = catalogContext;
			_configurationProvider = configurationProvider;
		}

		public PipelineExecutionResult Execute(UCommerce.EntitiesV2.PurchaseOrder subject)
		{
			if (subject.OrderTotal.GetValueOrDefault() > _vipThreshold)
			{
				var localizationContext = new CustomGlobalization(_configurationProvider);
				localizationContext.SetCulture(new CultureInfo(subject.CultureCode));

				var emailParams = new Dictionary<string, string>();
				emailParams.Add("orderGuid", subject.OrderGuid.ToString());
				emailParams.Add("orderValue", subject.OrderTotal.Value.ToString());

				_emailService.Send(
					localizationContext,
					_catalogContext.CurrentCatalogGroup.EmailProfile, 
					"vipOrder",
					new MailAddress("msk@ucommerce.net"), 
					emailParams);
			}

			return PipelineExecutionResult.Success;
		}
	}
}
