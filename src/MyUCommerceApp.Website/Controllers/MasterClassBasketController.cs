using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using MyUCommerceApp.Website.Models;
using UCommerce;
using UCommerce.Api;
using UCommerce.EntitiesV2;
using UCommerce.Runtime;

namespace MyUCommerceApp.Website.Controllers
{
	public class MasterClassBasketController : Umbraco.Web.Mvc.RenderMvcController
    {
        public ActionResult Index()
        {
            var basketModel = new PurchaseOrderViewModel();

            UCommerce.EntitiesV2.PurchaseOrder basket = UCommerce.Api.TransactionLibrary.GetBasket(false).PurchaseOrder;
            
            foreach (UCommerce.EntitiesV2.OrderLine basketOrderLine in basket.OrderLines)
            {
                OrderlineViewModel orderlineViewModel = new OrderlineViewModel();

                orderlineViewModel.Sku = basketOrderLine.Sku;
                orderlineViewModel.VariantSku = basketOrderLine.VariantSku;
                orderlineViewModel.ProductName = basketOrderLine.ProductName;
                orderlineViewModel.Quantity = basketOrderLine.Quantity;
                orderlineViewModel.OrderLineId = basketOrderLine.OrderLineId;
                orderlineViewModel.Total =
                    new UCommerce.Money(basketOrderLine.Total.GetValueOrDefault(), basket.BillingCurrency).ToString();

                basketModel.OrderLines.Add(orderlineViewModel);
            }
            //if (basket.BillingCurrency != SiteContext.Current.CatalogContext.CurrentPriceGroup.Currency)
            //{
            //    CatalogLibrary.ChangePriceGroup(SiteContext.Current.CatalogContext.CurrentPriceGroup, true);

            //}
            basketModel.OrderTotal = new UCommerce.Money(basket.OrderTotal.GetValueOrDefault(), basket.BillingCurrency).ToString();

            return View("/Views/mc/Basket.cshtml", basketModel);
        }

        [HttpPost]
        public ActionResult Index(PurchaseOrderViewModel model)
        {
            foreach (var orderlineViewModel in model.OrderLines)
            {
                int newQuantity = orderlineViewModel.Quantity;
                if (model.RemoveOrderlineId == orderlineViewModel.OrderLineId)
                {
                    newQuantity = 0;
                }  

                UCommerce.Api.TransactionLibrary.UpdateLineItem(orderlineViewModel.OrderLineId, newQuantity);
            }
            
            UCommerce.Api.TransactionLibrary.ExecuteBasketPipeline();

            return Redirect(this.CurrentPage.Url);
        }
    }
}