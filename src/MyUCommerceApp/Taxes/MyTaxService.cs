using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UCommerce;
using UCommerce.Catalog;
using UCommerce.EntitiesV2;

namespace MyUCommerceApp.Taxes
{
	public class MyTaxService : TaxService
	{
		private readonly IRepository<PriceGroup> _priceGroupRepository;

		public MyTaxService(IRepository<PriceGroup> priceGroupRepository)
		{
			_priceGroupRepository = priceGroupRepository;
		}

		public override Money CalculateTax(Product product, PriceGroup priceGroup, Money unitPrice)
		{
			int priceGroupId = 0;
			ProductProperty productProperty = product.ParentProduct == null ?
				product["OverrideVat"] : product.ParentProduct["OverrideVat"];

			if (productProperty != null && int.TryParse(productProperty.Value, out priceGroupId))
			{
				priceGroup = _priceGroupRepository.Get(priceGroupId) ?? priceGroup;
			}

			return base.CalculateTax(product, priceGroup, unitPrice);
		}
	}
}
