using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UCommerce;
using UCommerce.Catalog;
using UCommerce.EntitiesV2;

namespace MyUCommerceApp.BusinessLogic.Pricing
{
	public class ExtendedTaxService : TaxService
	{
		private readonly IRepository<PriceGroup> _priceGroupRepository;

		public ExtendedTaxService(IRepository<PriceGroup> priceGroupRepository)
		{
			_priceGroupRepository = priceGroupRepository;
		}

		public override Money CalculateTax(Product product, PriceGroup priceGroup, Money unitPrice)
		{
			var productFamily = product.ParentProduct ?? product;

			var priceGroupProperty =
				productFamily
					.ProductProperties
					.FirstOrDefault(x => x.ProductDefinitionField.DataType.DefinitionName == "PriceGroup");

			if (priceGroupProperty != null)
			{
				if (priceGroupProperty.GetValue() != null)
				{
					string priceGroupId = priceGroupProperty.GetValue().ToString();
					if (priceGroupId != "-1")
					{
						var overridenPriceGroup = _priceGroupRepository.Get(Convert.ToInt32(priceGroupId));

						return CalculateTax(overridenPriceGroup, unitPrice);
					}
				}
			}

			return CalculateTax(priceGroup, unitPrice);
		}
	}
}
