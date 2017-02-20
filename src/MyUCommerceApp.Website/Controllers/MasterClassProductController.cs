using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using UCommerce.EntitiesV2;
using UCommerce.Extensions;
using UCommerce.Runtime;
using UCommerce.Api;

using MyUCommerceApp.Website.Models;

namespace MyUCommerceApp.Website.Controllers
{
	public class MasterClassProductController : Umbraco.Web.Mvc.RenderMvcController
    {
		public ActionResult Index()
		{
		    ProductViewModel productModel = MapProduct(UCommerce.Runtime.SiteContext.Current.CatalogContext.CurrentProduct);
            
            return View("/views/mc/product.cshtml", productModel);
		}

        private ProductViewModel MapProduct(UCommerce.EntitiesV2.Product currentProduct)
        {
            var model = new ProductViewModel();

            model.Sku = currentProduct.Sku;
            model.Name = currentProduct.DisplayName();
            model.LongDescription = currentProduct.LongDescription();
            model.PriceCalculation = UCommerce.Api.CatalogLibrary
                .CalculatePrice(currentProduct);

            model.VariantSku = currentProduct.VariantSku;
            model.IsVariant = currentProduct.IsVariant;

            foreach (var currentProductVariant in currentProduct.Variants)
            {
                model.Variants.Add(MapProduct(currentProductVariant));
            }

            return model;
        }

        [HttpPost]
		public ActionResult Index(AddToBasketViewModel model)
        {
            UCommerce.Api.TransactionLibrary.AddToBasket(1, model.Sku, model.VariantSku);

            return Index();
        }
    }
}