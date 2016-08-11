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
	public class ProductController : System.Web.Mvc.Controller
	{
		public ActionResult Index()
		{
			ProductViewModel productModel = new ProductViewModel();

			return View("/views/product.cshtml", productModel);
		}

		private IList<ProductViewModel> MapVariants(ICollection<UCommerce.EntitiesV2.Product> productsToMap)
		{
			var productModels = new List<ProductViewModel>();

			return productModels;
		}

		[HttpPost]
		public ActionResult Index(AddToBasketViewModel model)
		{
			return Index();
		}
	}
}