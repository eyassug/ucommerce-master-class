using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using UCommerce.Api;
using UCommerce.EntitiesV2;
using UCommerce.Extensions;
using UCommerce.MasterClass.Website.Models;
using UCommerce.Runtime;

namespace UCommerce.MasterClass.Website.Controllers
{
	public class CategoryController : System.Web.Mvc.Controller
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