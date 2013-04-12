using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UCommerce;
using UCommerce.Catalog;
using UCommerce.EntitiesV2;

namespace MyUCommerceApp.Library.Pricing
{
	public class MyTaxService : TaxService
	{
		public override Money CalculateTax(
			PriceGroup priceGroup, Money amount)
		{
			return base.CalculateTax(priceGroup, amount);
		}

		public override Money CalculateTax(
			Product product, 
			PriceGroup priceGroup, 
			Money unitPrice)
		{
			ProductProperty x = (product.ParentProduct != null)
				                    ? product.ParentProduct["TaxExempt"]
				                    : product["TaxExempt"];
			
			if (x != null && x.Value == "True")
				return new Money(0m, priceGroup.Currency);

			return base.CalculateTax(product, priceGroup, unitPrice);
		}
	}
}
