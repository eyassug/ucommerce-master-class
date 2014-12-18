using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web;
using UCommerce.Content;
using UCommerce.EntitiesV2;
using UCommerce.Security;

namespace MyUCommerceApp.CatalogContext
{
	public class MyCatalogContext : UCommerce.Runtime.CatalogContext
	{
		private readonly IMemberService _memberService;

		public MyCatalogContext(
			IMemberService memberService,
			IDomainService domainService, 
			IRepository<ProductCatalogGroup> productCatalogGroupRepository, 
			IRepository<ProductCatalog> productCatalogRepository, 
			IRepository<PriceGroup> priceGroupRepository) : base(domainService, productCatalogGroupRepository, productCatalogRepository, priceGroupRepository)
		{
			_memberService = memberService;
		}

		private bool IsLoggedIn()
		{
			if (HttpContext.Current.Request.QueryString["IsLoggedIn"] != null
				|| _memberService.IsLoggedIn())
				return true;

			return false;
		}

		public override string CurrentCatalogName
		{
			get
			{
				if (IsLoggedIn())
					return "Private";

				return base.CurrentCatalogName;
			}
			set { base.CurrentCatalogName = value; }
		}
	}
}
