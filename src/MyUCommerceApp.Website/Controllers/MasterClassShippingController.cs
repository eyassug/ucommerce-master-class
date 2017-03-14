using System.Collections.Generic;
using System.Web.Mvc;
using MyUCommerceApp.Website.Models;
using UCommerce.Api;
using UCommerce.EntitiesV2;

namespace MyUCommerceApp.Website.Controllers
{
	public class MasterClassShippingController : Umbraco.Web.Mvc.RenderMvcController
    {
        [HttpGet]
        public ActionResult Index()
        {
            var shippingModel = new ShippingViewModel();

            OrderAddress shippingInformation = TransactionLibrary.GetShippingInformation();

            ICollection<ShippingMethod> availableShippingMethods =
                TransactionLibrary.GetShippingMethods(shippingInformation.Country);

            ShippingMethod selectedShippingMethod = UCommerce.Api.TransactionLibrary.GetShippingMethod();
            int selectedShippingMethodId = -1;
            if (selectedShippingMethod != null)
            {
                selectedShippingMethodId = selectedShippingMethod.ShippingMethodId;
            }

            foreach (var availableShippingMethod in availableShippingMethods)
            {
                shippingModel.AvailableShippingMethods.Add(new SelectListItem()
                {
                    Selected = selectedShippingMethodId == availableShippingMethod.ShippingMethodId,
                    Text =  availableShippingMethod.Name,
                    Value = availableShippingMethod.ShippingMethodId.ToString()
                });
            }
            return View("/Views/mc/Shipping.cshtml", shippingModel);
        }

        [HttpPost]
        public ActionResult Index(ShippingViewModel shipping)
        {
            TransactionLibrary.CreateShipment(
                shippingMethodId: shipping.SelectedShippingMethodId,
                addressName:null, 
                overwriteExisting:true);

            TransactionLibrary.ExecuteBasketPipeline();
            return Redirect("/payment");
		}
	}
}