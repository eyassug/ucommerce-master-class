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
	public class NofityOnVipCustomerTask : IPipelineTask<PurchaseOrder>
	{
		private readonly IEmailService _emailService;
		private readonly ILocalizationContext _localizationContext;
		private readonly ICatalogContext _catalogContext;
		private readonly IRepository<EmailType> _emailTypeRepository;
		private readonly int _vipThreshold;
		private readonly string _vipEmailType;

		public NofityOnVipCustomerTask(
			IEmailService emailService, 
			ILocalizationContext localizationContext,
			ICatalogContext catalogContext,
			IRepository<EmailType> emailTypeRepository,
			int vipThreshold,
			string vipEmailType)
		{
			_emailService = emailService;
			_localizationContext = localizationContext;
			_catalogContext = catalogContext;
			_emailTypeRepository = emailTypeRepository;
			_vipThreshold = vipThreshold;
			_vipEmailType = vipEmailType;
		}

		public PipelineExecutionResult Execute(PurchaseOrder subject)
		{
			if (subject.OrderTotal.GetValueOrDefault() < _vipThreshold)
				return PipelineExecutionResult.Success;

			var emailProfile = _catalogContext.CurrentCatalogGroup.EmailProfile;
			var emailContent = emailProfile.GetProfileInformation(
				_emailTypeRepository.SingleOrDefault(x => x.Name == _vipEmailType));

			var emailParameters = new Dictionary<string, string>();
			emailParameters.Add("orderGuid", subject.OrderGuid.ToString());
			emailParameters.Add("orderValue", subject.OrderTotal.GetValueOrDefault().ToString());

			_emailService.Send(
				_localizationContext, 
				emailProfile, 
				_vipEmailType, 
				new MailAddress(emailContent.CcAddress), 
				emailParameters);

			return PipelineExecutionResult.Success;
		}
	}
}
