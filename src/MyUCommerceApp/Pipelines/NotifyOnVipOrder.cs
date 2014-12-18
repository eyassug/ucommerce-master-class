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
		private readonly ICatalogContext _catalogContext;
		private readonly IEmailService _emailService;
		private readonly int _vipAmount;

		public NotifyOnVipOrder(
			CommerceConfigurationProvider commerceConfigurationProvider,
			ICatalogContext catalogContext,
			IEmailService emailService,
			int vipAmount)
		{
			_commerceConfigurationProvider = commerceConfigurationProvider;
			_catalogContext = catalogContext;
			_emailService = emailService;
			_vipAmount = vipAmount;
		}

		public PipelineExecutionResult Execute(PurchaseOrder subject)
		{
			if (subject.OrderTotal > _vipAmount)
			{
				var localizationContext = new CustomGlobalization(_commerceConfigurationProvider);
				localizationContext.SetCulture(new CultureInfo(subject.CultureCode));

				var emailParameters = new Dictionary<string, string>();
				emailParameters.Add("OrderGuid",subject.OrderGuid.ToString());
				
				_emailService.Send(
					localizationContext,
					_catalogContext.CurrentCatalogGroup.EmailProfile,
					"vipAmount", new MailAddress("msk@ucommerce.net"),
					emailParameters);
			}

			return PipelineExecutionResult.Success;
		}
	}
}
