using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web;
using UCommerce.Content;
using UCommerce.EntitiesV2;
using UCommerce.Runtime;
using UCommerce.Security;

namespace MyUCommerceApp.BusinessLogic.Sitecontext
{
	public class ExtendedCatalogContext : CatalogContext
	{
		private readonly IMemberService _memberService;

		public ExtendedCatalogContext(
			IMemberService memberService,
			IDomainService domainService, 
			IRepository<ProductCatalogGroup> productCatalogGroupRepository, 
			IRepository<ProductCatalog> productCatalogRepository, 
			IRepository<PriceGroup> priceGroupRepository) : base(domainService, productCatalogGroupRepository, productCatalogRepository, priceGroupRepository)
		{
			_memberService = memberService;
		}

		public override string CurrentCatalogName
		{
			get
			{
				if (IsLoggedIn())
				{
					return "Private";
				}

				return base.CurrentCatalogName;
			}
			set { base.CurrentCatalogName = value; }
		}

		protected virtual bool IsLoggedIn()
		{
			return _memberService.IsLoggedIn() || (HttpContext.Current.Request.QueryString["loggedIn"] != null);
		}
	}
}
