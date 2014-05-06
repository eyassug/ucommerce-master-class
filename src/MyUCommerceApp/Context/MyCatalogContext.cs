using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web;
using UCommerce.Content;
using UCommerce.EntitiesV2;
using UCommerce.Infrastructure;
using UCommerce.Infrastructure.Globalization;
using UCommerce.Runtime;
using UCommerce.Security;

namespace MyUCommerceApp.Context
{
	public class MyCatalogContext : CatalogContext 
	{
		private readonly IRepository<PriceGroup> _priceGroupRepository;
		private readonly IMemberService _memberService;

		public MyCatalogContext
			(
			IDomainService domainService, 
			IRepository<ProductCatalogGroup> productCatalogGroupRepository, 
			IRepository<ProductCatalog> productCatalogRepository, 
			IRepository<PriceGroup> priceGroupRepository,
			IMemberService memberService) 
		: base(
			domainService,
			productCatalogGroupRepository,
			productCatalogRepository,
			priceGroupRepository)
		{
			_priceGroupRepository = priceGroupRepository;
			_memberService = memberService;
		}

		public override string CurrentCatalogName
		{
			get
			{
				if (UserIsLoggedIn())
				{
					return "Private";
				}

				return base.CurrentCatalogName;
			}
			set { base.CurrentCatalogName = value; }
		}

		public override PriceGroup CurrentPriceGroup
		{
			get
			{
				var member = _memberService.GetCurrentMember();
				var memberType = GetMemberTypeFromLoggedInMember(member);

				var priceGroup = _priceGroupRepository.Select(x => x.Name == memberType).FirstOrDefault();

				if (priceGroup != null) return priceGroup;

				return base.CurrentPriceGroup;
			}
			set { base.CurrentPriceGroup = value; }
		}

		private string GetMemberTypeFromLoggedInMember(Member member)
		{
			return "B2B";
		}

		private bool UserIsLoggedIn()
		{
			return 
			_memberService.IsLoggedIn() ||
			HttpContext.Current.Request.QueryString["loggedin"] != null;
		}
	}
}
