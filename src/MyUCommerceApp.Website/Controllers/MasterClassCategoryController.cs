using System.Collections.Generic;
using System.Web.Mvc;
using UCommerce.EntitiesV2;
using MyUCommerceApp.Website.Models;
using UCommerce.Extensions;
using UCommerce.Runtime;

namespace MyUCommerceApp.Website.Controllers
{
	public class MasterClassCategoryController : Umbraco.Web.Mvc.RenderMvcController
    {
        [HttpGet]
        public ActionResult Index()
        {
            var categoryViewModel = new CategoryViewModel();

            var currentCategory = UCommerce.Runtime.SiteContext.Current.CatalogContext.CurrentCategory;
            categoryViewModel.Name = currentCategory.DisplayName();
            categoryViewModel.Description = currentCategory.Description();

            var productsInCategory = UCommerce.Api.CatalogLibrary.GetProducts(currentCategory);

            categoryViewModel.Products = MapProducts(productsInCategory);

            return View("/views/mc/category.cshtml", categoryViewModel);
        }

        private IList<ProductViewModel> MapProducts(ICollection<Product> productsInCategory)
        {
            IList<ProductViewModel> productViews = new List<ProductViewModel>();

            foreach (var product in productsInCategory)
            {
                var productViewModel = new ProductViewModel();

                productViewModel.Sku = product.Sku;
                productViewModel.Name = product.DisplayName();
                productViewModel.Url = "/product?product=" + product.ProductId;

                productViewModel.PriceCalculation = UCommerce.Api.CatalogLibrary.CalculatePrice(product);

                productViews.Add(productViewModel);
            }
            return productViews;
        }
    }
}