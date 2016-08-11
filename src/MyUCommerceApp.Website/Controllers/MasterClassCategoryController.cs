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
	public class MasterClassCategoryController : Umbraco.Web.Mvc.RenderMvcController
	{
		public ActionResult Index()
		{
			var categoryViewModel = new CategoryViewModel();

			return View("/views/category.cshtml",categoryViewModel);
		}

		private IList<ProductViewModel> MapProducts(ICollection<UCommerce.EntitiesV2.Product> productsInCategory)
		{
			IList<ProductViewModel> productViews = new List<ProductViewModel>();

			return productViews;
		}
	}
}