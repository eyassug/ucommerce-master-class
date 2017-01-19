using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UCommerce;
using UCommerce.EntitiesV2;

namespace MyUCommerceApp.BusinessLogic.Tax
{
    public class ExtendedTaxService : UCommerce.Catalog.TaxService
    {
        private readonly IRepository<PriceGroup> _priceGroupRepository;

        public ExtendedTaxService(IRepository<PriceGroup> priceGroupRepository)
        {
            _priceGroupRepository = priceGroupRepository;
        }
        public override Money CalculateTax(Product product, PriceGroup priceGroup, Money unitPrice)
        {
            if (product == null)
                return base.CalculateTax(product, priceGroup, unitPrice);

            var productProperty = product["PriceGroup"];

            if (productProperty == null && product.IsVariant)
            {
                productProperty = product.ParentProduct["PriceGroup"];
            }

            if (productProperty == null)
                return base.CalculateTax(product, priceGroup, unitPrice);

            var propertyValue = productProperty.GetValue().ToString();
            if (string.IsNullOrEmpty(propertyValue))
                return base.CalculateTax(product, priceGroup, unitPrice);

            int priceGroupId;
            if (int.TryParse(propertyValue, out priceGroupId))
            {
                var productPriceGroup = _priceGroupRepository.SingleOrDefault(x => x.PriceGroupId == priceGroupId);
                if (productPriceGroup != null)
                    return base.CalculateTax(product, productPriceGroup, unitPrice);
            }

            return base.CalculateTax(product, priceGroup, unitPrice);

        }
    }
}
