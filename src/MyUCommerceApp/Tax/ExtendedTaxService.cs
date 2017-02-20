using System.Linq;
using UCommerce;
using UCommerce.Catalog;
using UCommerce.EntitiesV2;

namespace MyUCommerceApp.BusinessLogic.Tax
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
            var priceGroupProperty = product["CustomPriceGroup"];

            if (priceGroupProperty == null && product.ParentProduct != null)
            {
                priceGroupProperty = product.ParentProduct["CustomPriceGroup"];
            }

            if(priceGroupProperty == null)
                return base.CalculateTax(product, priceGroup, unitPrice);

            int priceGroupId;
            if (int.TryParse(priceGroupProperty.GetValue().ToString(), out priceGroupId))
            {
                var overridenPriceGroup = _priceGroupRepository
                    .SingleOrDefault(x => x.PriceGroupId == priceGroupId);

                if (overridenPriceGroup != null)
                {
                    priceGroup = overridenPriceGroup;
                }
            }
            return base.CalculateTax(product, priceGroup, unitPrice);
        }
    }
}
