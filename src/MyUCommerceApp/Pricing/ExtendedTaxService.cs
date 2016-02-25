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
		public override Money CalculateTax(Product product, PriceGroup priceGroup, Money unitPrice)
		{
			return base.CalculateTax(product, priceGroup, unitPrice);
		}
	}
}
