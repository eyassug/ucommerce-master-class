using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Cache;
using System.Text;
using UCommerce.Content;
using UCommerce.EntitiesV2;
using UCommerce.Runtime;
using System.Web;
using UCommerce.Security;

namespace MyUCommerceApp.Context
{
	public class MyCatalogContext : CatalogContext
	{
		private readonly IMemberService _memberService;
		private string _currentCatalogName;

		public MyCatalogContext(
			IDomainService domainService, 
			IRepository<ProductCatalogGroup> productCatalogGroupRepository, 
			IRepository<ProductCatalog> productCatalogRepository, 
			IRepository<PriceGroup> priceGroupRepository,
			IMemberService memberService) : base(domainService, productCatalogGroupRepository, productCatalogRepository, priceGroupRepository)
		{
			_memberService = memberService;
		}

		public override string CurrentCatalogName
		{
			get
			{
				if (HttpContext.Current.Request.QueryString["loggedin"] != null ||
					_memberService.IsLoggedIn())
					return "Private";
				
				return base.CurrentCatalogName;
			}
			set
			{
				_currentCatalogName = value;
			}
		}
	}
}
