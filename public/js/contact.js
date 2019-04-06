$('document').ready(() => {

    // Initializing the character counter.
    $(document).ready(function () {
        $('.message-content input').characterCounter();
    });

    // Opening up the contact modal.
    $('#contact-btn').on('click', () => {
        (M.Modal.getInstance($('#contact-modal'))).open();
    });
    
    // Sending the message.
    $('#contact-form').on('submit', (e) => {

        // Preventing the page from reloading.
        e.preventDefault();

        // Sending the mail to the server.
        $.post('/dashboard/mail', $(e.target).serialize(), (data) => {

            if (data.sent === true) {

                M.toast({html: 'Message sent!'});
            } else {

                M.toast({html: 'Something went wrong!'});
            }
        });
    });
});