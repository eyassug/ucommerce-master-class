using System;
using System.Linq;
using System.Web;
using UCommerce.Content;
using UCommerce.EntitiesV2;
using UCommerce.Runtime;
using UCommerce.Security;

namespace MyUCommerceApp.Catalog
{
	public class MyCatalogContext : CatalogContext
	{
		private readonly IMemberService _memberService;

		public MyCatalogContext(IDomainService domainService, 
								IMemberService memberService,
								IRepository<ProductCatalogGroup> productCatalogGroupRepository, 
								IRepository<ProductCatalog> productCatalogRepository, 
								IRepository<PriceGroup> priceGroupRepository) 
			: base(domainService, productCatalogGroupRepository, productCatalogRepository, priceGroupRepository)
		{
			_memberService = memberService;
		}

		public override string CurrentCatalogName
		{
			get
			{
				if (_memberService.IsLoggedIn() || HttpContext.Current.Request.QueryString["LoggedIn"] != null)
				{
					return "Private";
				}
				return base.CurrentCatalogName;
			}
			set
			{
				base.CurrentCatalogName = value;
			}
		}

		public override PriceGroup CurrentPriceGroup
		{
			get
			{
				if (CurrentProduct == null)
					return base.CurrentPriceGroup;

				var property = CurrentProduct.ProductProperties
					.FirstOrDefault(x => x.GetDefinitionField().DataType.Name == "PriceGroup");

				if (property == null)
					return base.CurrentPriceGroup;

				if (property.Value.Equals("0"))
					return base.CurrentPriceGroup;
				
				return PriceGroup.Get(Convert.ToInt32(property.Value));
			}
			set
			{
				base.CurrentPriceGroup = value;
			}
		}
	}
}