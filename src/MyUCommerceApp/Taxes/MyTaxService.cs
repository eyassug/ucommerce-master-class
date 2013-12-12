using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UCommerce;
using UCommerce.Catalog;
using UCommerce.EntitiesV2;
using UCommerce.Extensions;

namespace MyUCommerceApp.Taxes
{
	public class MyTaxService : TaxService
	{
		public override Money CalculateTax(Product product, PriceGroup priceGroup, Money unitPrice)
		{
			var productProperty = product["VatGroup"];
			
			if (productProperty == null)
				productProperty = product.ParentProduct["VatGroup"];

			if (productProperty == null || productProperty.GetValue().ToString() == "")
				return base.CalculateTax(product, priceGroup, unitPrice);

			var stringValue = productProperty.GetValue().ToString();

			int priceGroupId = Convert.ToInt32(stringValue);

			var overriddenPriceGroup = PriceGroup.Get(priceGroupId);

			decimal unitTax = unitPrice.Value*overriddenPriceGroup.VATRate;
			
			return new Money(unitTax, unitPrice.Currency);
		}
	}
}
