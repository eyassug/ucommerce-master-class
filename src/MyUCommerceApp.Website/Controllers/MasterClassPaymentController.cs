﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using UCommerce.Api;
using UCommerce.EntitiesV2;
using MyUCommerceApp.Website.Models;

namespace MyUCommerceApp.Website.Controllers
{
	public class MasterClassPaymentController : Umbraco.Web.Mvc.RenderMvcController
    {
		public ActionResult Index()
		{
			var paymentViewModel = new PaymentViewModel();

			PurchaseOrder basket = TransactionLibrary.GetBasket(false).PurchaseOrder;

            var existingPayment = basket.Payments.FirstOrDefault();

            paymentViewModel.SelectedPaymentMethodId = existingPayment != null
                ? existingPayment.PaymentMethod.PaymentMethodId
                : -1;

            Country shippingCountry = TransactionLibrary.GetShippingInformation().Country;

			var availablePaymentMethods = TransactionLibrary.GetPaymentMethods(shippingCountry);
            
			foreach (var availablePaymentMethod in availablePaymentMethods)
			{
				var option = new SelectListItem();
				option.Text = availablePaymentMethod.Name;
				option.Value = availablePaymentMethod.PaymentMethodId.ToString();
				option.Selected = availablePaymentMethod.PaymentMethodId == paymentViewModel.SelectedPaymentMethodId;

				paymentViewModel.AvailablePaymentMethods.Add(option);
			}

			return View("/Views/Payment.cshtml", paymentViewModel);
		}

		[HttpPost]
		public ActionResult Index(PaymentViewModel payment)
		{
			TransactionLibrary.CreatePayment(
				paymentMethodId: payment.SelectedPaymentMethodId, 
				requestPayment: false, 
				amount: -1, 
				overwriteExisting: true);

			TransactionLibrary.ExecuteBasketPipeline();

			return Redirect("/preview");
		}

	}
}