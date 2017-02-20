using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using UCommerce.Api;
using UCommerce.EntitiesV2;
using UCommerce;
using MyUCommerceApp.Website.Models;

namespace MyUCommerceApp.Website.Controllers
{
	public class MasterClassPreviewController : Umbraco.Web.Mvc.RenderMvcController
    {
        public ActionResult Index()
        {
            PurchaseOrderViewModel basketModel = MapOrder();

            basketModel.BillingAddress = MapOrderAddress(TransactionLibrary.GetBillingInformation());
            basketModel.ShippingAddress = MapOrderAddress(TransactionLibrary.GetShippingInformation());

            var basket = UCommerce.Api.TransactionLibrary.GetBasket(false).PurchaseOrder;
            var billingCurrency = basket.BillingCurrency;

            foreach (var basketOrderLine in basket.OrderLines)
            {
                var orderLineViewModel = new OrderlineViewModel();

                orderLineViewModel.Sku = basketOrderLine.Sku;
                orderLineViewModel.VariantSku = basketOrderLine.VariantSku;
                orderLineViewModel.ProductName = basketOrderLine.ProductName;
                orderLineViewModel.Quantity = basketOrderLine.Quantity;

                orderLineViewModel.Total = new Money(basketOrderLine.Total.GetValueOrDefault(), billingCurrency).ToString();

                basketModel.OrderLines.Add(orderLineViewModel);
            }

            basketModel.SubTotal = new Money(basket.SubTotal.GetValueOrDefault(), billingCurrency).ToString();
            basketModel.TaxTotal = new Money(basket.TaxTotal.GetValueOrDefault(), billingCurrency).ToString();
            basketModel.DiscountTotal = new Money(basket.DiscountTotal.GetValueOrDefault(), billingCurrency).ToString();

            basketModel.ShippingTotal = GetMoneyFormat(basket.ShippingTotal, billingCurrency);
            basketModel.PaymentTotal = GetMoneyFormat(basket.PaymentTotal, billingCurrency);
            basketModel.OrderTotal = GetMoneyFormat(basket.OrderTotal, billingCurrency);

            return View("/Views/mc/preview.cshtml", basketModel);
        }

        private string GetMoneyFormat(decimal? value, Currency currency)
        {
            return new Money(value.GetValueOrDefault(), currency).ToString();
        }

        private AddressViewModel MapOrderAddress(OrderAddress orderAddress)
        {
            var addressDetails = new AddressViewModel();

            addressDetails.FirstName = orderAddress.FirstName;
            addressDetails.LastName = orderAddress.LastName;
            addressDetails.EmailAddress = orderAddress.EmailAddress;
            addressDetails.PhoneNumber = orderAddress.PhoneNumber;
            addressDetails.MobilePhoneNumber = orderAddress.MobilePhoneNumber;
            addressDetails.Line1 = orderAddress.Line1;
            addressDetails.Line2 = orderAddress.Line2;
            addressDetails.PostalCode = orderAddress.PostalCode;
            addressDetails.City = orderAddress.City;
            addressDetails.State = orderAddress.State;
            addressDetails.Attention = orderAddress.Attention;
            addressDetails.CompanyName = orderAddress.CompanyName;
            addressDetails.CountryId = orderAddress.Country != null ? orderAddress.Country.CountryId : -1;

            return addressDetails;
        }

        private PurchaseOrderViewModel MapOrder()
        {
            var basketModel = new PurchaseOrderViewModel();

            return basketModel;
        }

        [HttpPost]
        public ActionResult Index(bool checkout)
        {
            TransactionLibrary.RequestPayments();

            return View("/Views/mc/Complete.cshtml");
        }
    }
}