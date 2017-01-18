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
            PurchaseOrderViewModel model = MapOrder();

            PurchaseOrder basket = TransactionLibrary.GetBasket(false).PurchaseOrder;

            //Get order for email content using querystring - the cookie no longer works.
            //var order = TransactionLibrary.GetPurchaseOrder(Guid.Parse(Request.QueryString["OrderGuid"]));

            model.BillingAddress = MapOrderAddress(TransactionLibrary.GetBillingInformation());
            model.ShippingAddress = MapOrderAddress(TransactionLibrary.GetShippingInformation());

            foreach (OrderLine orderLine in basket.OrderLines)
            {
                var orderLineModel = new OrderlineViewModel();
                orderLineModel.Sku = orderLine.Sku;
                orderLineModel.VariantSku = orderLine.VariantSku;
                orderLineModel.ProductName = orderLine.ProductName;
                orderLineModel.Total = new UCommerce.Money(orderLine.Total.GetValueOrDefault(), basket.BillingCurrency).ToString();
                orderLineModel.Quantity = orderLine.Quantity;
                
                model.OrderLines.Add(orderLineModel);

            }

            model.OrderTotal = new Money(basket.OrderTotal.GetValueOrDefault(), basket.BillingCurrency).ToString();
            model.SubTotal = new Money(basket.SubTotal.GetValueOrDefault(), basket.BillingCurrency).ToString();
            model.PaymentTotal = new Money(basket.PaymentTotal.GetValueOrDefault(), basket.BillingCurrency).ToString();
            model.ShippingTotal = new Money(basket.ShippingTotal.GetValueOrDefault(), basket.BillingCurrency).ToString();
            model.TaxTotal = new Money(basket.TaxTotal.GetValueOrDefault(), basket.BillingCurrency).ToString();
            model.DiscountTotal = new Money(basket.DiscountTotal.GetValueOrDefault(), basket.BillingCurrency).ToString();

            return View("/Views/mc/preview.cshtml", model);
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
            UCommerce.Api.TransactionLibrary.RequestPayments();
            return View("/Views/mc/Complete.cshtml");
        }
    }
}