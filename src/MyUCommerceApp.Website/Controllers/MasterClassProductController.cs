using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using UCommerce.Api;
using UCommerce.EntitiesV2;
using UCommerce.Extensions;
using MyUCommerceApp.Website.Models;

namespace MyUCommerceApp.Website.Controllers
{
    public class MasterClassProductController : Umbraco.Web.Mvc.RenderMvcController
    {
        public ActionResult Index()
        {
            var currentProduct = UCommerce.Runtime.SiteContext.Current.CatalogContext.CurrentProduct;

            ProductViewModel productModel = new ProductViewModel();

            productModel.PriceCalculation = UCommerce.Api.CatalogLibrary.CalculatePrice(currentProduct);
            productModel.Sku = currentProduct.Sku;
            productModel.Name = currentProduct.DisplayName();
            productModel.LongDescription = currentProduct.LongDescription();
            productModel.Variants = MapVariants(currentProduct.Variants);
            productModel.IsVariant = currentProduct.ProductDefinition.IsProductFamily();

            return View("/views/product.cshtml", productModel);
        }

        private IList<ProductViewModel> MapVariants(ICollection<Product> variants)
        {
            var variantModels = new List<ProductViewModel>();

            foreach (var currentProduct in variants)
            {
                ProductViewModel productModel = new ProductViewModel();

                productModel.Sku = currentProduct.Sku;
                productModel.VariantSku = currentProduct.VariantSku;
                productModel.Name = currentProduct.DisplayName();
                productModel.LongDescription = currentProduct.LongDescription();
                productModel.Variants = MapVariants(currentProduct.Variants);

                variantModels.Add(productModel);
            }

            return variantModels;
        }

        [HttpPost]
        public ActionResult Index(AddToBasketViewModel model)
        {
            UCommerce.Api.TransactionLibrary.AddToBasket(1, model.Sku, model.VariantSku);

            return Index();
        }
    }
}