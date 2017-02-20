using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using MyUCommerceApp.Website.Models;
using UCommerce;
using UCommerce.Api;
using UCommerce.EntitiesV2;

namespace MyUCommerceApp.Website.Controllers
{
	public class MasterClassBasketController : Umbraco.Web.Mvc.RenderMvcController
    {
        public ActionResult Index()
        {
            var basketModel = new PurchaseOrderViewModel();

            UCommerce.EntitiesV2.PurchaseOrder basket = 
                UCommerce.Api.TransactionLibrary.GetBasket(false).PurchaseOrder;

            UCommerce.EntitiesV2.Currency billingCurrency = basket.BillingCurrency;

            basketModel.OrderTotal = 
                new Money(basket.OrderTotal.GetValueOrDefault(), billingCurrency).ToString();

            foreach (var orderLine in basket.OrderLines)
            {
                var orderLineViewModel = new OrderlineViewModel();

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
            foreach (var orderlineViewModel in model.OrderLines)
            {
                int newQuantity = orderlineViewModel.Quantity;
                int orderlineId = orderlineViewModel.OrderLineId;

                if (model.RemoveOrderlineId == orderlineId)
                {
                    newQuantity = 0;
                }

                UCommerce.Api.TransactionLibrary.UpdateLineItem(orderlineId, newQuantity);
            }

            UCommerce.Api.TransactionLibrary.ExecuteBasketPipeline();

            return Redirect(this.CurrentPage.Url);
        }
    }
}