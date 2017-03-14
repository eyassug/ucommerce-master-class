using System.Collections.Generic;
using System.Web.Mvc;
using UCommerce.EntitiesV2;
using MyUCommerceApp.Website.Models;
using UCommerce.Extensions;
using UCommerce.Runtime;
using UCommerce.Api;

namespace MyUCommerceApp.Website.Controllers
{
	public class MasterClassProductController : Umbraco.Web.Mvc.RenderMvcController
    {
        [HttpGet]
        public ActionResult Index()
		{
			ProductViewModel productModel = new ProductViewModel();

		    productModel = MapProduct(UCommerce.Runtime.SiteContext.Current.CatalogContext.CurrentProduct);

            return View("/views/mc/product.cshtml", productModel);
		}

		private ProductViewModel MapProduct(UCommerce.EntitiesV2.Product product)
		{
            var model = new ProductViewModel();

		    model.Sku = product.Sku;
		    model.Name = product.DisplayName();
		    model.LongDescription = product.LongDescription();
		    model.PriceCalculation = UCommerce.Api.CatalogLibrary.CalculatePrice(product);

		    model.VariantSku = product.VariantSku;
		    model.IsVariant = product.IsVariant;

		    foreach (var productVariant in product.Variants)
		    {
		        model.Variants.Add(MapProduct(productVariant));
		    }

            return model;
		}

		[HttpPost]
		public ActionResult Index(AddToBasketViewModel model)
		{
		    TransactionLibrary.AddToBasket(1, model.Sku, model.VariantSku);
            return Index();
        }
    }
}