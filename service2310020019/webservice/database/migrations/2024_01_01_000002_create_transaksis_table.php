<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('transaksis', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('id_keranjang');
            $table->integer('status')->default(0);
            $table->string('waktu_pesan');
            $table->string('waktu_bayar')->nullable();
            $table->string('created_at')->nullable();
            $table->string('updated_at')->nullable();
            
            $table->foreign('id_keranjang')->references('id')->on('keranjangs')->onDelete('cascade');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('transaksis');
    }
};
