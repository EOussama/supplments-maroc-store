$('document').ready(() => {

    // Initializing tabs.
    $('.dashboard-flavors .tabs').tabs();

    // Initializing the character counter.
    $('#flavors-creation-tab input[type=text], #flavors-edition-tab input[type=text]').characterCounter();

    // Initializing the collapsibles.
    $('.dashboard-flavors .collapsible').collapsible();
});
