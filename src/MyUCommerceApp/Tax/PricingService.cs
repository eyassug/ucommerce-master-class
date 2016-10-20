using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UCommerce;
using UCommerce.EntitiesV2;

namespace MyUCommerceApp.BusinessLogic.Tax
{
    public class PricingService : UCommerce.Catalog.PricingService
    {
        public override Money GetProductPrice(Product product, PriceGroup priceGroup)
        {
            return base.GetProductPrice(product, priceGroup);
        }
    }
}
