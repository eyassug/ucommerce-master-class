using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UCommerce;
using UCommerce.Catalog;
using UCommerce.EntitiesV2;

namespace MyUCommerceApp.BusinessLogic.Pricing
{
	public class ExtendedPricingService : PricingService
	{
		private readonly IRepository<PriceGroup> _priceGroupRepository;

		public ExtendedPricingService(IRepository<PriceGroup> priceGroupRepository)
		{
			_priceGroupRepository = priceGroupRepository;
		}

		public override Money GetProductPrice(Product product, PriceGroup priceGroup)
		{
			var productProperty = product
									.ProductProperties
									.FirstOrDefault(
										property => property.ProductDefinitionField.DataType.DefinitionName == "PriceGroup");
			
			if (productProperty == null && product.ParentProduct != null)
			{
				productProperty = product
									.ParentProduct
									.ProductProperties
									.FirstOrDefault(property => 
										property.ProductDefinitionField.DataType.DefinitionName == "PriceGroup");
			}

			if (productProperty != null)
			{
				if (!string.IsNullOrEmpty(productProperty.Value))
				{
					int priceGroupId;
					if (int.TryParse(productProperty.Value, out priceGroupId))
					{
						var potentialPriceGroup = _priceGroupRepository.Select().Where(x => x.PriceGroupId == priceGroupId).FirstOrDefault();
						if (potentialPriceGroup != null)
						{
							priceGroup = potentialPriceGroup;
						}
					}
 				}
			}

			return base.GetProductPrice(product, priceGroup);
		}
	}
}
