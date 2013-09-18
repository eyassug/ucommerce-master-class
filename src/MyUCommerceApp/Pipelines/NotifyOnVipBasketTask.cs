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

namespace MyUCommerceApp.Pipelines
{
	public class NotifyOnVipBasketTask : IPipelineTask<PurchaseOrder>
	{
		private readonly IEmailService _emailService;
		private readonly ILocalizationContext _localizationContext;
		private readonly ICatalogContext _catalogContext;
		private readonly decimal _vipBasketThreshold;

		public NotifyOnVipBasketTask(
			IEmailService emailService, 
			ILocalizationContext localizationContext,
			ICatalogContext catalogContext,
			decimal vipBasketThreshold)
		{
			_emailService = emailService;
			_localizationContext = localizationContext;
			_catalogContext = catalogContext;
			_vipBasketThreshold = vipBasketThreshold;
		}

		public PipelineExecutionResult Execute(PurchaseOrder subject)
		{
			if (subject.OrderTotal > _vipBasketThreshold)
			{
				// send email
				_emailService.Send(
					_localizationContext,
					_catalogContext.CurrentCatalogGroup.EmailProfile,
					"VipBasketNotification",
					new MailAddress("ssl@ucommerce.net"),
					new Dictionary<string, string>());
			}

			return PipelineExecutionResult.Success;
		}
	}
}
