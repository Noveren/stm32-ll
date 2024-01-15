#pragma once

#include "resource.hh"
namespace res = resource;

class FM25V05 {
    FM25V05(res::spi::SerialPeripheralInterface* spi, res::pin::PushPull* nss);
    // {
    //     nss->set_high();
    // };
};