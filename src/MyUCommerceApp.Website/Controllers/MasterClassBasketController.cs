using System.Web.Mvc;
using MyUCommerceApp.Website.Models;
using UCommerce;
using UCommerce.Api;
using UCommerce.EntitiesV2;

namespace MyUCommerceApp.Website.Controllers
{
	public class MasterClassBasketController : Umbraco.Web.Mvc.RenderMvcController
    {
        [HttpGet]
        public ActionResult Index()
        {
            var basketModel = new PurchaseOrderViewModel();

            UCommerce.EntitiesV2.PurchaseOrder basket = UCommerce.Api.TransactionLibrary.GetBasket(false).PurchaseOrder;

            UCommerce.EntitiesV2.Currency billingCurrency = basket.BillingCurrency;

            basketModel.OrderTotal = new Money(basket.OrderTotal.GetValueOrDefault(), billingCurrency).ToString();

            foreach (var orderLine in basket.OrderLines)
            {
                var orderLineViewModel = new  OrderlineViewModel();

                orderLineViewModel.Quantity = orderLine.Quantity;
                orderLineViewModel.ProductName = orderLine.ProductName;
                orderLineViewModel.Sku = orderLine.Sku;
                orderLineViewModel.VariantSku = orderLine.VariantSku;
                orderLineViewModel.Total = new Money(orderLine.Total.GetValueOrDefault(), billingCurrency).ToString();
                orderLineViewModel.OrderLineId = orderLine.OrderLineId;

                basketModel.OrderLines.Add(orderLineViewModel);
            }

            return View("/Views/mc/Basket.cshtml", basketModel);
        }

        [HttpPost]
        public ActionResult Index(PurchaseOrderViewModel model)
        {
            foreach (var orderLine in model.OrderLines)
            {
                int newQuantity = orderLine.Quantity;
                int orderLineId = orderLine.OrderLineId;

                if (model.RemoveOrderlineId == orderLineId)
                {
                    newQuantity = 0;
                }

                UCommerce.Api.TransactionLibrary.UpdateLineItem(orderLineId, newQuantity);
            }

            UCommerce.Api.TransactionLibrary.ExecuteBasketPipeline();

            return Redirect(this.CurrentPage.Url);
        }
    }
}