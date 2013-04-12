using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UCommerce;
using UCommerce.Catalog;
using UCommerce.EntitiesV2;

namespace MyUCommerceApp.Library
{
	public class MyPricingService : IPricingService
	{
		public Money GetProductPrice(Product product, PriceGroup priceGroup)
		{
			return new Money(0m, priceGroup.Currency);
		}
	}
}
