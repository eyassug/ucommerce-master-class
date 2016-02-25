using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UCommerce.Content;
using UCommerce.EntitiesV2;
using UCommerce.Runtime;
using UCommerce.Security;

namespace MyUCommerceApp.BusinessLogic.SiteContext
{
	public class ExtendedCatalogContext : CatalogContext
	{
		private readonly IMemberService _memberService;

		public ExtendedCatalogContext(
			IDomainService domainService, 
			IRepository<ProductCatalogGroup> productCatalogGroupRepository, 
			IRepository<ProductCatalog> productCatalogRepository, 
			IRepository<PriceGroup> priceGroupRepository,
			IMemberService memberService) 
			: base(domainService, productCatalogGroupRepository, productCatalogRepository, priceGroupRepository)
		{
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

		protected virtual bool UserIsLoggedIn()
		{
//			return _memberService.IsLoggedIn(); //realy should use the Member service to observe SRP In SOLID.
			return System.Web.HttpContext.Current.Request.QueryString["UserIsLoggedIn"] != null;
		}
	}
}
