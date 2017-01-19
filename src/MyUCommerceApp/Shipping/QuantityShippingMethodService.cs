using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UCommerce;
using UCommerce.EntitiesV2;
using UCommerce.Transactions.Shipping;

namespace MyUCommerceApp.BusinessLogic.Shipping
{
    public class QuantityShippingMethodService : IShippingMethodService
    {
        public Money CalculateShippingPrice(Shipment shipment)
        {
            var shippingCosts = shipment.OrderLines.Sum(orderLine => orderLine.Quantity);

            return new Money(shippingCosts * 10, shipment.PurchaseOrder.BillingCurrency);
        }

        public bool ValidateForShipping(Shipment shipment)
        {
            throw new NotImplementedException();
        }
    }
}
