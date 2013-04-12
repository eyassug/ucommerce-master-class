using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Mail;
using System.Text;
using System.Threading.Tasks;
using UCommerce.EntitiesV2;
using UCommerce.Infrastructure.Globalization;
using UCommerce.Pipelines;
using UCommerce.Runtime;
using UCommerce.Transactions;

namespace MyUCommerceApp.Library
{
	public class NotifyOnVipBasketTask : IPipelineTask<PurchaseOrder>
	{
		private readonly IEmailService _emailService;
		private readonly ILocalizationContext _localizationContext;
		private readonly ICatalogContext _catalogContext;
		private readonly int _vipOrderThresHold;

		public NotifyOnVipBasketTask(
			IEmailService emailService, 
			ILocalizationContext localizationContext,
			ICatalogContext catalogContext,
			int vipOrderThresHold)
		{
			_emailService = emailService;
			_localizationContext = localizationContext;
			_catalogContext = catalogContext;
			_vipOrderThresHold = vipOrderThresHold;
		}

		public PipelineExecutionResult Execute(PurchaseOrder subject)
		{
			if (subject.OrderTotal > _vipOrderThresHold
				&& subject["VIPBasket"] == null)
			{
				subject["VIPBasket"] = "true";

				EmailProfile profile = 
					_catalogContext.CurrentCatalogGroup.EmailProfile;

				var parameters = new Dictionary<string, string>();
				parameters.Add("orderGuid", subject.OrderGuid.ToString());

				_emailService.Send(
					_localizationContext,
					profile,
					"VipBasketNotification",
					new MailAddress("test@test.com"),
					parameters);
			}
			return PipelineExecutionResult.Success;
		}
	}
}
