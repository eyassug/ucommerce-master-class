using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using MyUCommerceApp.Website.Models;
using UCommerce.Api;
using UCommerce.EntitiesV2;

namespace MyUCommerceApp.Website.Controllers
{
	public class MasterClassShippingController : Umbraco.Web.Mvc.RenderMvcController
    {
        public ActionResult Index()
        {
            var shippingModel = new ShippingViewModel();

            UCommerce.EntitiesV2.OrderAddress shippingInformation =
                UCommerce.Api.TransactionLibrary.GetShippingInformation();

            ICollection<ShippingMethod> availableShippingMethod =
                TransactionLibrary.GetShippingMethods(shippingInformation.Country);

            ShippingMethod selectedShippingMethod = TransactionLibrary.GetShippingMethod();
            int selectedShippingMethodId = -1;
            if (selectedShippingMethod != null)
            {
                selectedShippingMethodId = selectedShippingMethod.ShippingMethodId;
            }

            foreach (var shippingMethod in availableShippingMethod)
            {
                shippingModel.AvailableShippingMethods.Add(new SelectListItem()
                {
                    Selected = selectedShippingMethodId == shippingMethod.ShippingMethodId,
                    Text = shippingMethod.Name,
                    Value = shippingMethod.ShippingMethodId.ToString()
                });
            }

            return View("/Views/mc/Shipping.cshtml", shippingModel);
        }

        [HttpPost]
        public ActionResult Index(ShippingViewModel shipping)
        {
            TransactionLibrary.CreateShipment(
                shippingMethodId: shipping.SelectedShippingMethodId,
                addressName: null,
                overwriteExisting: true
                );
               
            TransactionLibrary.ExecuteBasketPipeline();

            return Redirect("/payment");
		}
	}
}