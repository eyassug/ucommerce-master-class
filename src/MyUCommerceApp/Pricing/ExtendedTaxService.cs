using System.Linq;
using NHibernate.Intercept;
using UCommerce;
using UCommerce.Catalog;
using UCommerce.EntitiesV2;

namespace MyUCommerceApp.BusinessLogic.Pricing
{
    public class ExtendedTaxService : TaxService
    {
        private readonly IRepository<PriceGroup> _repository;

        public ExtendedTaxService(IRepository<PriceGroup> repository)
        {
            _repository = repository;
        }

        public override Money CalculateTax(Product product, PriceGroup priceGroup, Money unitPrice)
        {
            var priceGroupProperty = product["PriceGroup"];

            if (priceGroupProperty == null && product.ParentProduct != null)
            {
                priceGroupProperty = product.ParentProduct["PriceGroup"];
            }

            if(priceGroupProperty == null)
                return base.CalculateTax(product, priceGroup, unitPrice);

            if(priceGroupProperty.GetValue() == null)
                return base.CalculateTax(product, priceGroup, unitPrice);

            int priceGroupId;
            if (int.TryParse(priceGroupProperty.GetValue().ToString(), out priceGroupId))
            {
                var overridenPriceGroup = _repository.Get(priceGroupId);

                if (overridenPriceGroup != null)
                {
                    priceGroup = overridenPriceGroup;
                }
            }

            return base.CalculateTax(product, priceGroup, unitPrice);
        }
    }
}
