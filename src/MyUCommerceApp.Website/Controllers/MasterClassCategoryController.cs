using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using UCommerce.EntitiesV2;
using UCommerce.Api;
using UCommerce.Runtime;
using UCommerce.Extensions;
using MyUCommerceApp.Website.Models;

namespace MyUCommerceApp.Website.Controllers
{
	public class MasterClassCategoryController : Umbraco.Web.Mvc.RenderMvcController
	{
        public ActionResult Index()
        {
            var categoryViewModel = new CategoryViewModel();

            var currentCategory 
                = UCommerce.Runtime.SiteContext.Current.CatalogContext.CurrentCategory;

            categoryViewModel.Name = currentCategory.DisplayName();

            return View("/views/category.cshtml", categoryViewModel);
        }

        private IList<ProductViewModel> MapProducts(ICollection<Product> productsInCategory)
        {
            IList<ProductViewModel> productViews = new List<ProductViewModel>();

            return productViews;
        }
    }
}