using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using UCommerce.EntitiesV2;
using UCommerce.Api;
using MyUCommerceApp.Website.Models;

namespace MyUCommerceApp.Website.Controllers
{
	public class MasterClassShippingController : Umbraco.Web.Mvc.RenderMvcController
    {
        public ActionResult Index()
        {
            ShippingViewModel shippingModel = new ShippingViewModel();
            UCommerce.EntitiesV2.PurchaseOrder basket = TransactionLibrary.GetBasket(false).PurchaseOrder;

            int selectedShippingMethodId = 0;
            var existingShipment = basket.Shipments.FirstOrDefault();
            if (existingShipment != null)
            {
                selectedShippingMethodId = existingShipment.ShippingMethod.ShippingMethodId;
            }

            Country country = TransactionLibrary.GetShippingInformation().Country;
            ICollection<ShippingMethod> availableShippingMethods = UCommerce.Api.TransactionLibrary.GetShippingMethods(country);

            foreach (UCommerce.EntitiesV2.ShippingMethod availableShippingMethod in availableShippingMethods)
            {
                var item = new SelectListItem();
                item.Text = availableShippingMethod.Name;
                item.Value = availableShippingMethod.ShippingMethodId.ToString();
                item.Selected = availableShippingMethod.ShippingMethodId == selectedShippingMethodId;

                shippingModel.AvailableShippingMethods.Add(item);
            }

            return View("/Views/mc/Shipping.cshtml", shippingModel);
        }

        [HttpPost]
        public ActionResult Index(ShippingViewModel shipping)
        {
            UCommerce.Api.TransactionLibrary.CreateShipment(shipping.SelectedShippingMethodId, overwriteExisting: true);
            UCommerce.Api.TransactionLibrary.ExecuteBasketPipeline();

            return Redirect("/payment");
		}
	}
}