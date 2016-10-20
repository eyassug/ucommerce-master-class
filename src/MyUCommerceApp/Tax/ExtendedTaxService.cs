using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UCommerce;
using UCommerce.Catalog;
using UCommerce.EntitiesV2;

namespace MyUCommerceApp.BusinessLogic.Tax
{
    public class ExtendedTaxService : TaxService
    {
        IRepository<PriceGroup> _priceGroupRepository;

        public ExtendedTaxService(IRepository<PriceGroup> priceGroupRepository)
        {
            _priceGroupRepository = priceGroupRepository;
        }

        public override Money CalculateTax(Product product, PriceGroup priceGroup, Money unitPrice)
        {
            var priceGroupProperty = product["PriceGroup"];

            if (priceGroupProperty == null && product.ParentProduct != null)
            {
                priceGroupProperty = product.ParentProduct["PriceGroup"];
            }

            if (priceGroupProperty == null)
                return base.CalculateTax(product, priceGroup, unitPrice);

            var priceGroupValue = priceGroupProperty.GetValue();

            if (priceGroupValue == null || string.IsNullOrEmpty(priceGroupValue.ToString()))
                return base.CalculateTax(product, priceGroup, unitPrice);

            int priceGroupId;
            if (int.TryParse(priceGroupValue.ToString(), out priceGroupId)) 
            {
                var taxPriceGroup = _priceGroupRepository
                                        .Select(x => x.PriceGroupId == priceGroupId)
                                        .FirstOrDefault();

                if (taxPriceGroup != null)
                {
                    return base.CalculateTax(product, taxPriceGroup, unitPrice);
                }
            }

            return base.CalculateTax(product, priceGroup, unitPrice);
        }
    }
}
