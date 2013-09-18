using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web;
using UCommerce.Content;
using UCommerce.EntitiesV2;
using UCommerce.Runtime;
using UCommerce.Security;

namespace MyUCommerceApp.Context
{
	public class MyCatalogContext : CatalogContext
	{
		private readonly IMemberService _memberService;
		private readonly IRepository<ProductCatalog> _productCatalogRepository;
		private ProductCatalog _currentCatalog1;

		public MyCatalogContext(
			IDomainService domainService,
 			IMemberService memberService,
			IRepository<ProductCatalogGroup> productCatalogGroupRepository, 
			IRepository<ProductCatalog> productCatalogRepository, 
			IRepository<PriceGroup> priceGroupRepository) : base(domainService, productCatalogGroupRepository, productCatalogRepository, priceGroupRepository)
		{
			_memberService = memberService;
			_productCatalogRepository = productCatalogRepository;
		}

		public override ProductCatalog CurrentCatalog
		{
			get
			{
				if (_memberService.IsLoggedIn())
					return _productCatalogRepository.SingleOrDefault(x => x.Name == "Private");

				return base.CurrentCatalog;
			}
			set
			{
				base.CurrentCatalog = value;
			}
		}
	}
}
