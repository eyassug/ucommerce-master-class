using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UCommerce;
using UCommerce.Catalog;
using UCommerce.EntitiesV2;
using UCommerce.Extensions;

namespace MyUCommerceApp.Library
{
	public class MyTaxService : TaxService
	{
		public override Money CalculateTax(Product product, PriceGroup priceGroup, Money unitPrice)
		{
			bool taxExempt = product.GetPropertyValue<bool>("TaxExempt");
			if (taxExempt)
				return new Money(0, priceGroup.Currency);

			return base.CalculateTax(product, priceGroup, unitPrice);
		}

		public override Money CalculateTax(PriceGroup priceGroup, Money amount)
		{
			return base.CalculateTax(priceGroup, amount);
		}
	}
}
