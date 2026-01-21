<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Transaksi extends Model
{
    protected $table = 'transaksis';
    
    public $timestamps = false;

    protected $fillable = [
        'id_keranjang',
        'status',
        'waktu_pesan',
        'waktu_bayar',
        'created_at',
        'updated_at',
    ];

    public function keranjang()
    {
        return $this->belongsTo(Keranjang::class, 'id_keranjang');
    }
}
