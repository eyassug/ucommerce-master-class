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
		private readonly CommerceConfigurationProvider _commerceConfigurationProvider;
		private readonly IEmailService _emailService;
		private readonly ICatalogContext _catalogContext;
		private readonly int _vipAmountThreshold;

		public NotifyOnVipOrder(
			CommerceConfigurationProvider commerceConfigurationProvider, 
			IEmailService emailService,
 			ICatalogContext catalogContext,
			int vipAmountThreshold)
		{
			_commerceConfigurationProvider = commerceConfigurationProvider;
			_emailService = emailService;
			_catalogContext = catalogContext;
			_vipAmountThreshold = vipAmountThreshold;
		}

		public PipelineExecutionResult Execute(PurchaseOrder subject)
		{
			if (subject.OrderTotal.Value > _vipAmountThreshold)
			{
				var localizationContext = new CustomGlobalization(_commerceConfigurationProvider);
				localizationContext.SetCulture(new CultureInfo(subject.CultureCode));

				var emailParams = new Dictionary<string, string>();
				emailParams.Add("orderGuid", subject.OrderGuid.ToString());
				emailParams.Add("orderValue",subject.OrderTotal.Value.ToString());

				_emailService.Send(
					localizationContext,
					_catalogContext.CurrentCatalogGroup.EmailProfile,
					"VipEmail", new MailAddress("msk@ucommerce.net"), emailParams);
			}

			return PipelineExecutionResult.Success;
		}
	}
}
