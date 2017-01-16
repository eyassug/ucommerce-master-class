using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using MyUCommerceApp.Website.Models;
using UCommerce.EntitiesV2;
using UCommerce.Api;
using UCommerce.Extensions;

namespace MyUCommerceApp.Website.Controllers
{
	public class MasterClassPartialViewController : Umbraco.Web.Mvc.SurfaceController
    {
        public ActionResult CategoryNavigation()
        {
            var categoryNavigation = new CategoryNavigationViewModel();

            categoryNavigation.Categories = MapCategories(UCommerce.Api.CatalogLibrary.GetRootCategories());

            return View("/views/mc/PartialViews/CategoryNavigation.cshtml", categoryNavigation);
        }

        private IList<CategoryViewModel> MapCategories(ICollection<UCommerce.EntitiesV2.Category> categoriesToMap)
        {
            List<CategoryViewModel> categoriesToReturn = new List<CategoryViewModel>();

            foreach (UCommerce.EntitiesV2.Category categoryToMap in categoriesToMap)
            {
                CategoryViewModel model = new CategoryViewModel();
                model.Name = categoryToMap.DisplayName();
                model.Categories = MapCategories(UCommerce.Api.CatalogLibrary.GetCategories(categoryToMap));
                model.Url = "/category?category=" + categoryToMap.CategoryId;
                categoriesToReturn.Add(model);
            }

            return categoriesToReturn;
        }
    }
}