using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UCommerce.EntitiesV2;
using UCommerce.Transactions.Payments;

namespace MyUCommerceApp.BusinessLogic.Payments
{
    public class MyCustomPaymentGateWayImplementaion : ExternalPaymentMethodService
    {
        public override Payment RequestPayment(PaymentRequest paymentRequest)
        {
            return base.RequestPayment(paymentRequest);
        }

        public override string RenderPage(PaymentRequest paymentRequest)
        {
            throw new NotImplementedException();
        }

        public override void ProcessCallback(Payment payment)
        {
            //if the user is redirected then you need to redirect the user in here.
            //If this is a server to server request, don't do anything
            throw new NotImplementedException();
        }

        protected override bool CancelPaymentInternal(Payment payment, out string status)
        {
            throw new NotImplementedException();
        }

        protected override bool AcquirePaymentInternal(Payment payment, out string status)
        {
            throw new NotImplementedException();
        }

        protected override bool RefundPaymentInternal(Payment payment, out string status)
        {
            throw new NotImplementedException();
        }
    }
}
